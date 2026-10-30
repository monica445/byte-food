import { Router } from "express";
import * as shopController from "./shop.controller.js";

const router = Router();

router.get("/", shopController.getShops);
router.get("/:shopId", shopController.getShopById);

export default router;
