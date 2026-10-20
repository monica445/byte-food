import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { AppLanguage, UserRole } from "../../generated/prisma/client.js";
import { prisma } from "../../lib/prisma.js";
import type { LoginInput, RegisterInput } from "./auth.schema.ts";

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN ?? "15m";

if (!JWT_SECRET || Buffer.byteLength(JWT_SECRET, "utf8") < 32) {
  throw new Error("JWT_SECRET must contain at least 32 bytes");
}

function publicUser(
  user: {
    id: string;
    name: string;
    email: string;
    phone: string | null;
    role: UserRole;
    preferredLanguage: AppLanguage;
    isActive?: boolean;
  } | null,
) {
  if (!user) {
    throw new Error("USER_NOT_FOUND");
  }

  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    preferredLanguage: user.preferredLanguage,
    isActive: user.isActive ?? true,
  };
}

function createAccessToken(userId: string): string {
  return jwt.sign({}, JWT_SECRET!, {
    subject: userId,
    issuer: "byteme-api",
    audience: "byteme-app",
    expiresIn: JWT_EXPIRES_IN as jwt.SignOptions["expiresIn"],
    algorithm: "HS256",
  });
}

export async function registerCustomer(input: RegisterInput) {
  if (Buffer.byteLength(input.password, "utf8") > 72) {
    throw new Error("PASSWORD_TOO_LONG");
  }

  const passwordHash = await bcrypt.hash(input.password, 12);

  try {
    const user = await prisma.user.create({
      data: {
        name: input.name,
        email: input.email,
        passwordHash,
        role: UserRole.CUSTOMER,
      },
    });

    return {
      user: publicUser(user),
      accessToken: createAccessToken(user.id),
    };
  } catch (error) {
    // Prisma unique constraint violation: email already exists.
    if (
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      error.code === "P2002"
    ) {
      throw new Error("EMAIL_ALREADY_REGISTERED");
    }

    throw error;
  }
}

export async function login(input: LoginInput) {
  if (Buffer.byteLength(input.password, "utf8") > 72) {
    throw new Error("INVALID_CREDENTIALS");
  }

  const user = await prisma.user.findUnique({
    where: { email: input.email },
  });

  // Generic response avoids revealing whether an email exists.
  if (!user || !(await bcrypt.compare(input.password, user.passwordHash))) {
    throw new Error("INVALID_CREDENTIALS");
  }

  return {
    user: publicUser(user),
    accessToken: createAccessToken(user.id),
  };
}

export async function getCurrentUser(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    throw new Error("USER_NOT_FOUND");
  }

  return publicUser(user);
}
