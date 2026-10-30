import type { Request, Response, NextFunction } from "express";
import * as shopService from "./shop.service.js";

// GET /api/shops
export const getShops = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const categoryId =
      typeof req.query.categoryId === "string"
        ? req.query.categoryId
        : undefined;

    const search =
      typeof req.query.search === "string"
        ? req.query.search.trim()
        : undefined;

    let isOpen: boolean | undefined;

    if (req.query.isOpen !== undefined) {
      if (req.query.isOpen !== "true" && req.query.isOpen !== "false") {
        res.status(400).json({
          success: false,
          message: "isOpen must be true or false",
        });
        return;
      }

      isOpen = req.query.isOpen === "true";
    }

    const pageValue = Number(req.query.page ?? 1);
    const limitValue = Number(req.query.limit ?? 10);

    if (
      !Number.isInteger(pageValue) ||
      !Number.isInteger(limitValue) ||
      pageValue < 1 ||
      limitValue < 1
    ) {
      res.status(400).json({
        success: false,
        message: "Page and limit must be positive integers",
      });
      return;
    }

    const page = pageValue;
    const limit = Math.min(limitValue, 50);

    const result = await shopService.getShops({
      categoryId,
      search: search || undefined,
      isOpen,
      page,
      limit,
    });

    res.status(200).json({
      success: true,
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/shops/:shopId
export const getShopById = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { shopId } = req.params;

    const shop = await shopService.getShopById(shopId as string);

    if (!shop) {
      res.status(404).json({
        success: false,
        message: "Shop not found",
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: shop,
    });
  } catch (error) {
    next(error);
  }
};
