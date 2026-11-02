import { Router } from "express";
import rateLimit from "express-rate-limit";
import { authenticate } from "./auth.middleware.js";
import { loginUser, me, register } from "./auth.controller.js";

const router = Router();

const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: "draft-8",
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many attempts. Please try again later.",
  },
});

router.post("/register", authRateLimit, register);
router.post("/login", authRateLimit, loginUser);
router.get("/me", authenticate, me);

export default router;
