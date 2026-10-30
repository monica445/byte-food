import type { RequestHandler } from "express";
import { ZodError } from "zod";
import { loginSchema, registerSchema } from "./auth.schema.js";
import { getCurrentUser, login, registerCustomer } from "./auth.service.js";

export const register: RequestHandler = async (req, res, next) => {
  try {
    const input = registerSchema.parse(req.body);
    const result = await registerCustomer(input);

    res.status(201).json({
      success: true,
      data: result,
    });
  } catch (error) {
    if (error instanceof ZodError) {
      res.status(400).json({
        success: false,
        message: "Invalid registration details",
        errors: error.issues.map((issue) => ({
          field: issue.path.join("."),
          message: issue.message,
        })),
      });
      return;
    }

    if (error instanceof Error && error.message === "PASSWORD_TOO_LONG") {
      res.status(400).json({
        success: false,
        message: "Password is too long",
      });
      return;
    }

    if (
      error instanceof Error &&
      error.message === "EMAIL_ALREADY_REGISTERED"
    ) {
      res.status(409).json({
        success: false,
        message: "An account with this email already exists",
      });
      return;
    }

    next(error);
  }
};

export const loginUser: RequestHandler = async (req, res, next) => {
  try {
    const input = loginSchema.parse(req.body);
    const result = await login(input);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    if (error instanceof ZodError) {
      res.status(400).json({
        success: false,
        message: "Invalid login details",
      });
      return;
    }

    if (error instanceof Error && error.message === "INVALID_CREDENTIALS") {
      res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
      return;
    }

    if (error instanceof Error && error.message === "ACCOUNT_DISABLED") {
      res.status(403).json({
        success: false,
        message: "This account is unavailable",
      });
      return;
    }

    next(error);
  }
};

export const me: RequestHandler = async (_req, res, next) => {
  try {
    const authUser = res.locals.authUser as { id: string } | undefined;

    if (!authUser) {
      res.status(401).json({
        success: false,
        message: "Authentication required",
      });
      return;
    }

    const user = await getCurrentUser(authUser.id);

    if (!user) {
      res.status(401).json({
        success: false,
        message: "Account is unavailable",
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: { user },
    });
  } catch (error) {
    next(error);
  }
};
