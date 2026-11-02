import type { RequestHandler } from "express";
import jwt, { type JwtPayload } from "jsonwebtoken";
import { UserRole } from "../../generated/prisma/enums.js";
import { prisma } from "../../lib/prisma.js";
const JWT_SECRET = process.env.JWT_SECRET!;

type AuthUser = {
  id: string;
  role: UserRole;
};

export const authenticate: RequestHandler = async (req, res, next) => {
  try {
    const authorization = req.headers.authorization;

    if (!authorization?.startsWith("Bearer ")) {
      res.status(401).json({
        success: false,
        message: "Authentication required",
      });
      return;
    }

    const token = authorization.slice("Bearer ".length).trim();

    if (!token || token.length > 4096) {
      res.status(401).json({
        success: false,
        message: "Invalid or expired token",
      });
      return;
    }

    const decoded = jwt.verify(token, JWT_SECRET, {
      algorithms: ["HS256"],
      issuer: "byteme-api",
      audience: "byteme-app",
    });

    if (typeof decoded === "string" || !(decoded as JwtPayload).sub) {
      res.status(401).json({
        success: false,
        message: "Invalid or expired token",
      });
      return;
    }

    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
      select: { id: true, role: true },
    });

    if (!user) {
      res.status(401).json({
        success: false,
        message: "Account is unavailable",
      });
      return;
    }

    res.locals.authUser = {
      id: user.id,
      role: user.role,
    } satisfies AuthUser;

    next();
  } catch (error) {
    if (
      error instanceof jwt.JsonWebTokenError ||
      error instanceof jwt.TokenExpiredError
    ) {
      res.status(401).json({
        success: false,
        message: "Invalid or expired token",
      });
      return;
    }

    next(error);
  }
};

export function authorize(...allowedRoles: UserRole[]): RequestHandler {
  return (_req, res, next) => {
    const user = res.locals.authUser as AuthUser | undefined;

    if (!user) {
      res.status(401).json({
        success: false,
        message: "Authentication required",
      });
      return;
    }

    if (!allowedRoles.includes(user.role)) {
      res.status(403).json({
        success: false,
        message: "You do not have permission to perform this action",
      });
      return;
    }

    next();
  };
}
