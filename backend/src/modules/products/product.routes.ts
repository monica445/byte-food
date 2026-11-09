
import { Router } from "express";
import { UserRole } from "../../generated/prisma/enums.js";
import { productController } from "./product.controller.js";
import { authenticate, authorize } from "../auth/auth.middleware.js";

const publicRouter = Router();
const sellerRouter = Router();

// PUBLIC ROUTES
publicRouter.get("/", productController.getPublicProducts);
publicRouter.get("/:productId", productController.getPublicProductById);

// SELLER ROUTES
sellerRouter.use(authenticate);
sellerRouter.use(authorize(UserRole.SELLER));

sellerRouter.get("/", productController.getSellerProducts);
sellerRouter.post("/", productController.createProduct);
sellerRouter.patch("/:productId", productController.updateProduct);
sellerRouter.delete("/:productId", productController.deleteProduct);

export { publicRouter, sellerRouter };
