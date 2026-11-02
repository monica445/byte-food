import { Router } from "express";
import * as shopCategoryController from "./shop-category.controller.js";

const router = Router();

router.get("/", shopCategoryController.getShopCategories);

export default router;
