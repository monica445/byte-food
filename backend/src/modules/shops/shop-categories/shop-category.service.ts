import { prisma } from "../../../lib/prisma.js";

export const getShopCategories = async () => {
  return prisma.shopCategory.findMany({
    where: {
      isActive: true,
    },
    select: {
      id: true,
      name: true,
      slug: true,
      description: true,
      imageUrl: true,
      sortOrder: true,
    },
    orderBy: [{ sortOrder: "asc" }, { name: "asc" }],
  });
};
