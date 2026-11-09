
import { prisma } from "../../lib/prisma.js";

interface ProductQuery {
  q?: string;
  categoryId?: string;
  shopId?: string;
  page?: number;
  limit?: number;
}

interface CreateProductInput {
  name: string;
  description?: string;
  price: number;
  imageUrl?: string;
  categoryId?: string;
}

interface UpdateProductInput {
  name?: string;
  description?: string;
  price?: number;
  imageUrl?: string;
  categoryId?: string | null;
  isAvailable?: boolean;
}

const productInclude = {
  category: {
    select: {
      id: true,
      name: true,
      sortOrder: true,
    },
  },
  shop: {
    select: {
      id: true,
      name: true,
      logoUrl: true,
      isOpen: true,
    },
  },
};

function validateProductInput(input: {
  name?: string;
  price?: number;
}) {
  if (input.name !== undefined && !input.name.trim()) {
    throw Object.assign(new Error("Product name is required"), {
      statusCode: 400,
    });
  }

  if (
    input.price !== undefined &&
    (!Number.isInteger(input.price) || input.price <= 0)
  ) {
    throw Object.assign(new Error("Price must be a positive integer"), {
      statusCode: 400,
    });
  }
}

async function getSellerShop(sellerId: string) {
  const shop = await prisma.shop.findUnique({
    where: { sellerId },
    select: { id: true },
  });

  if (!shop) {
    throw Object.assign(new Error("You don't have a shop yet"), {
      statusCode: 404,
    });
  }

  return shop;
}

async function validateCategory(
  categoryId: string | null | undefined,
  shopId: string,
) {
  if (!categoryId) return;

  const category = await prisma.productCategory.findFirst({
    where: {
      id: categoryId,
      shopId,
    },
  });

  if (!category) {
    throw Object.assign(
      new Error("Product category not found in your shop"),
      { statusCode: 404 },
    );
  }
}

export const productService = {
  // CUSTOMER: Browse available products from approved shops.
  async getPublicProducts(query: ProductQuery) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(50, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where = {
      isAvailable: true,
      shop: {
        isApproved: true,
      },
      ...(query.shopId && {
        shopId: query.shopId,
      }),
      ...(query.categoryId && {
        categoryId: query.categoryId,
      }),
      ...(query.q && {
        name: {
          contains: query.q.trim(),
          mode: "insensitive" as const,
        },
      }),
    };

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        include: productInclude,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
      prisma.product.count({ where }),
    ]);

    return {
      products,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  },

  // CUSTOMER: Get one available product.
  async getPublicProductById(productId: string) {
    const product = await prisma.product.findFirst({
      where: {
        id: productId,
        isAvailable: true,
        shop: {
          isApproved: true,
        },
      },
      include: productInclude,
    });

    if (!product) {
      throw Object.assign(new Error("Product not found"), {
        statusCode: 404,
      });
    }

    return product;
  },

  // SELLER: Get products belonging to their own shop.
  async getSellerProducts(
    sellerId: string,
    query: ProductQuery,
  ) {
    const shop = await getSellerShop(sellerId);

    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(50, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where = {
      shopId: shop.id,
      ...(query.categoryId && {
        categoryId: query.categoryId,
      }),
      ...(query.q && {
        name: {
          contains: query.q.trim(),
          mode: "insensitive" as const,
        },
      }),
    };

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        include: productInclude,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
      prisma.product.count({ where }),
    ]);

    return {
      products,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  },

  // SELLER: Create a product.
  async createProduct(
    sellerId: string,
    input: CreateProductInput,
  ) {
    validateProductInput(input);

    const shop = await getSellerShop(sellerId);

    await validateCategory(input.categoryId, shop.id);

    const product = await prisma.product.create({
      data: {
        shopId: shop.id,
        categoryId: input.categoryId || null,
        name: input.name.trim(),
        description: input.description,
        price: input.price,
        imageUrl: input.imageUrl,
      },
      include: productInclude,
    });

    return product;
  },

  // SELLER: Update a product.
  async updateProduct(
    sellerId: string,
    productId: string,
    input: UpdateProductInput,
  ) {
    validateProductInput(input);

    const shop = await getSellerShop(sellerId);

    const existingProduct = await prisma.product.findFirst({
      where: {
        id: productId,
        shopId: shop.id,
      },
    });

    if (!existingProduct) {
      throw Object.assign(new Error("Product not found"), {
        statusCode: 404,
      });
    }

    if (input.categoryId !== undefined && input.categoryId !== null) {
      await validateCategory(input.categoryId, shop.id);
    }

    const product = await prisma.product.update({
      where: { id: productId },
      data: {
        ...(input.name !== undefined && {
          name: input.name.trim(),
        }),
        ...(input.description !== undefined && {
          description: input.description,
        }),
        ...(input.price !== undefined && {
          price: input.price,
        }),
        ...(input.imageUrl !== undefined && {
          imageUrl: input.imageUrl,
        }),
        ...(input.categoryId !== undefined && {
          categoryId: input.categoryId,
        }),
        ...(input.isAvailable !== undefined && {
          isAvailable: input.isAvailable,
        }),
      },
      include: productInclude,
    });

    return product;
  },

  // SELLER: Delete a product.
  async deleteProduct(sellerId: string, productId: string) {
    const shop = await getSellerShop(sellerId);

    const product = await prisma.product.findFirst({
      where: {
        id: productId,
        shopId: shop.id,
      },
    });

    if (!product) {
      throw Object.assign(new Error("Product not found"), {
        statusCode: 404,
      });
    }

    await prisma.product.delete({
      where: { id: productId },
    });

    return product;
  },
};
