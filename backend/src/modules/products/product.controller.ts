
import type { Request, Response, NextFunction } from "express";
import { productService } from "./product.service.js";

type AuthenticatedRequest = Request & { user: { id: string } };

export const productController = {
  // GET /api/products
  async getPublicProducts(
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    try {
      const result = await productService.getPublicProducts({
        q: req.query.q as string,
        categoryId: req.query.categoryId as string,
        shopId: req.query.shopId as string,
        page: Number(req.query.page) || 1,
        limit: Number(req.query.limit) || 20,
      });

      res.status(200).json({
        success: true,
        data: result.products,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  },

  // GET /api/products/:productId
  async getPublicProductById(
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    try {
      const product = await productService.getPublicProductById(
        req.params.productId as string,
      );

      res.status(200).json({
        success: true,
        data: product,
      });
    } catch (error) {
      next(error);
    }
  },

  // GET /api/seller/products
  async getSellerProducts(
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    try {
      const result = await productService.getSellerProducts(
        (req as AuthenticatedRequest).user.id,
        {
          q: req.query.q as string,
          categoryId: req.query.categoryId as string,
          page: Number(req.query.page) || 1,
          limit: Number(req.query.limit) || 20,
        },
      );

      res.status(200).json({
        success: true,
        data: result.products,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  },

  // POST /api/seller/products
  async createProduct(
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    try {
      const product = await productService.createProduct(
        (req as AuthenticatedRequest).user.id,
        req.body,
      );

      res.status(201).json({
        success: true,
        message: "Product created successfully",
        data: product,
      });
    } catch (error) {
      next(error);
    }
  },

  // PATCH /api/seller/products/:productId
  async updateProduct(
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    try {
      const product = await productService.updateProduct(
        (req as AuthenticatedRequest).user.id,
        req.params.productId as string,
        req.body,
      );

      res.status(200).json({
        success: true,
        message: "Product updated successfully",
        data: product,
      });
    } catch (error) {
      next(error);
    }
  },

  // DELETE /api/seller/products/:productId
  async deleteProduct(
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    try {
      await productService.deleteProduct(
        (req as AuthenticatedRequest).user.id,
        req.params.productId as string,
      );

      res.status(200).json({
        success: true,
        message: "Product deleted successfully",
      });
    } catch (error) {
      next(error);
    }
  },
};
