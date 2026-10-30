import { prisma } from "../../lib/prisma.js";

interface GetShopsParams {
  categoryId?: string;
  search?: string;
  isOpen?: boolean;
  page: number;
  limit: number;
}

// GET /api/shops
export const getShops = async ({
  categoryId,
  search,
  isOpen,
  page,
  limit,
}: GetShopsParams) => {
  const where = {
    isApproved: true,

    ...(categoryId && {
      shopCategoryId: categoryId,
    }),

    ...(isOpen !== undefined && {
      isOpen,
    }),

    ...(search && {
      OR: [
        {
          name: {
            contains: search,
            mode: "insensitive" as const,
          },
        },
        {
          description: {
            contains: search,
            mode: "insensitive" as const,
          },
        },
        {
          address: {
            contains: search,
            mode: "insensitive" as const,
          },
        },
      ],
    }),
  };

  const [shops, total] = await Promise.all([
    prisma.shop.findMany({
      where,

      select: {
        id: true,
        name: true,
        description: true,
        logoUrl: true,
        coverUrl: true,
        address: true,
        latitude: true,
        longitude: true,
        isOpen: true,

        shopCategory: {
          select: {
            id: true,
            name: true,
            slug: true,
          },
        },
      },

      orderBy: [{ isOpen: "desc" }, { createdAt: "desc" }],

      skip: (page - 1) * limit,
      take: limit,
    }),

    prisma.shop.count({
      where,
    }),
  ]);

  return {
    data: shops,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

// GET /api/shops/:shopId
export const getShopById = async (shopId: string) => {
  return prisma.shop.findFirst({
    where: {
      id: shopId,
      isApproved: true,
    },

    select: {
      id: true,
      name: true,
      description: true,
      logoUrl: true,
      coverUrl: true,
      address: true,
      latitude: true,
      longitude: true,
      isOpen: true,

      shopCategory: {
        select: {
          id: true,
          name: true,
          slug: true,
        },
      },

      productCategories: {
        where: {
          products: {
            some: {
              isAvailable: true,
            },
          },
        },

        select: {
          id: true,
          name: true,
          sortOrder: true,

          products: {
            where: {
              isAvailable: true,
            },

            select: {
              id: true,
              name: true,
              description: true,
              price: true,
              imageUrl: true,
              isAvailable: true,
            },

            orderBy: {
              createdAt: "desc",
            },
          },
        },

        orderBy: {
          sortOrder: "asc",
        },
      },

      createdAt: true,
    },
  });
};
