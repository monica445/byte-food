import { z } from "zod";

const emailSchema = z
  .string()
  .trim()
  .max(254, "Email must not exceed 254 characters.")
  .pipe(
    z.email({
      error: "Please enter a valid email address.",
    }),
  )
  .transform((email) => email.toLowerCase());

export const registerSchema = z
  .object({
    name: z.string().trim().min(2).max(100),
    email: emailSchema,
    password: z.string().min(8).max(72),
  })
  .strict();

export const loginSchema = z
  .object({
    email: emailSchema,
    password: z.string().min(1).max(72),
  })
  .strict();

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
