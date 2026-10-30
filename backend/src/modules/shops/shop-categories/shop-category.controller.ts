import type { Request, Response, NextFunction } from "express";
import * as shopCategoryService from "./shop-category.service.js";

export const getShopCategories = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const categories = await shopCategoryService.getShopCategories();

    res.status(200).json({
      success: true,
      data: categories,
    });
  } catch (error) {
    next(error);
  }
};
