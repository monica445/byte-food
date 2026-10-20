import "dotenv/config";
import bcrypt from "bcryptjs";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../src/generated/prisma/client.js";

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is missing from backend/.env");
}

const adapter = new PrismaPg({ connectionString });
const prisma = new PrismaClient({ adapter });

const demoPassword = "ByteMe123!";
const passwordHash = await bcrypt.hash(demoPassword, 12);

async function main() {
  // 1. Create sample shop categories.
  const categoryData = [
    { name: "Coffee & Drinks", slug: "coffee-drinks", sortOrder: 1 },
    { name: "Fast Food", slug: "fast-food", sortOrder: 2 },
    { name: "Khmer Food", slug: "khmer-food", sortOrder: 3 },
  ];

  const shopCategories = new Map<string, string>();

  for (const data of categoryData) {
    const category = await prisma.shopCategory.upsert({
      where: { slug: data.slug },
      update: {
        name: data.name,
        sortOrder: data.sortOrder,
        isActive: true,
      },
      create: { ...data, isActive: true },
    });

    shopCategories.set(data.slug, category.id);
  }

  // 2. Create a test customer.
  const customer = await prisma.user.upsert({
    where: { email: "customer@byteme.test" },
    update: {
      name: "Monica",
      passwordHash,
      role: "CUSTOMER",
      preferredLanguage: "EN",
    },
    create: {
      name: "Monica",
      email: "customer@byteme.test",
      passwordHash,
      role: "CUSTOMER",
      preferredLanguage: "EN",
    },
  });

  // 3. Create sample sellers and their shops.
  const shopData = [
    {
      email: "seller.coffee@byteme.test",
      sellerName: "Coffee Seller",
      name: "Mekong Coffee",
      description: "Fresh coffee, iced drinks, and sweet treats.",
      slug: "coffee-drinks",
      address: "BKK1, Phnom Penh, Cambodia",
      lat: 11.5564,
      lon: 104.9282,
      logoUrl:
        "https://images.unsplash.com/photo-1445116572660-236099ec97a0?auto=format&fit=crop&w=400&q=80",
      coverUrl:
        "https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=1200&q=80",
      products: [
        {
          category: "Coffee",
          name: "Iced Americano",
          description: "Espresso served over ice.",
          price: 7000,
          imageUrl:
            "https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80",
        },
        {
          category: "Coffee",
          name: "Iced Latte",
          description: "Espresso with fresh milk over ice.",
          price: 9000,
          imageUrl:
            "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=800&q=80",
        },
        {
          category: "Tea",
          name: "Milk Tea",
          description: "Creamy milk tea served cold.",
          price: 8000,
          imageUrl:
            "https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=80",
        },
      ],
    },
    {
      email: "seller.burger@byteme.test",
      sellerName: "Burger Seller",
      name: "Orange Bite Burger",
      description: "Burgers, fries, and quick meals.",
      slug: "fast-food",
      address: "Toul Tom Poung, Phnom Penh, Cambodia",
      lat: 11.5421,
      lon: 104.9175,
      logoUrl:
        "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80",
      coverUrl:
        "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1200&q=80",
      products: [
        {
          category: "Burgers",
          name: "Classic Beef Burger",
          description: "Beef patty, lettuce, tomato, and house sauce.",
          price: 15000,
          imageUrl:
            "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80",
        },
        {
          category: "Burgers",
          name: "Chicken Burger",
          description: "Crispy chicken with fresh vegetables.",
          price: 12000,
          imageUrl:
            "https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=800&q=80",
        },
        {
          category: "Sides",
          name: "French Fries",
          description: "Golden, crispy fries.",
          price: 6000,
          imageUrl:
            "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=800&q=80",
        },
      ],
    },
    {
      email: "seller.khmer@byteme.test",
      sellerName: "Khmer Food Seller",
      name: "Taste of Khmer",
      description: "Everyday Cambodian meals and local favorites.",
      slug: "khmer-food",
      address: "Toul Kork, Phnom Penh, Cambodia",
      lat: 11.5795,
      lon: 104.891,
      logoUrl:
        "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=400&q=80",
      coverUrl:
        "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80",
      products: [
        {
          category: "Rice Meals",
          name: "Chicken Rice",
          description: "Rice served with seasoned chicken.",
          price: 12000,
          imageUrl:
            "https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80",
        },
        {
          category: "Rice Meals",
          name: "Fried Rice",
          description: "Stir-fried rice with egg and vegetables.",
          price: 10000,
          imageUrl:
            "https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80",
        },
        {
          category: "Noodles",
          name: "Stir-Fried Noodles",
          description: "Noodles tossed with vegetables and sauce.",
          price: 11000,
          imageUrl:
            "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=800&q=80",
        },
      ],
    },
  ];

  for (const data of shopData) {
    const seller = await prisma.user.upsert({
      where: { email: data.email },
      update: {
        name: data.sellerName,
        passwordHash,
        role: "SELLER",
      },
      create: {
        name: data.sellerName,
        email: data.email,
        passwordHash,
        role: "SELLER",
      },
    });

    const shopCategoryId = shopCategories.get(data.slug);

    if (!shopCategoryId) {
      throw new Error(`Missing shop category: ${data.slug}`);
    }

    const shop = await prisma.shop.upsert({
      where: { sellerId: seller.id },
      update: {
        name: data.name,
        description: data.description,
        shopCategoryId,
        address: data.address,
        latitude: data.lat,
        longitude: data.lon,
        logoUrl: data.logoUrl,
        coverUrl: data.coverUrl,
        isOpen: true,
        isApproved: true,
      },
      create: {
        sellerId: seller.id,
        name: data.name,
        description: data.description,
        shopCategoryId,
        address: data.address,
        latitude: data.lat,
        longitude: data.lon,
        logoUrl: data.logoUrl,
        coverUrl: data.coverUrl,
        isOpen: true,
        isApproved: true,
      },
    });

    // Create each product category for this shop.
    const productCategoryIds = new Map<string, string>();

    for (const categoryName of [
      ...new Set(data.products.map((product) => product.category)),
    ]) {
      let category = await prisma.productCategory.findFirst({
        where: { shopId: shop.id, name: categoryName },
      });

      if (category) {
        category = await prisma.productCategory.update({
          where: { id: category.id },
          data: { sortOrder: productCategoryIds.size + 1 },
        });
      } else {
        category = await prisma.productCategory.create({
          data: {
            shopId: shop.id,
            name: categoryName,
            sortOrder: productCategoryIds.size + 1,
          },
        });
      }

      productCategoryIds.set(categoryName, category.id);
    }

    // Create or update products by shop and product name.
    for (const productData of data.products) {
      const categoryId = productCategoryIds.get(productData.category);

      const existingProduct = await prisma.product.findFirst({
        where: { shopId: shop.id, name: productData.name },
      });

      const productFields = {
        shopId: shop.id,
        categoryId,
        name: productData.name,
        description: productData.description,
        price: productData.price,
        imageUrl: productData.imageUrl,
        isAvailable: true,
      };

      if (existingProduct) {
        await prisma.product.update({
          where: { id: existingProduct.id },
          data: productFields,
        });
      } else {
        await prisma.product.create({ data: productFields });
      }
    }
  }

  // 4. Add a sample delivery address for the customer.
  const addressData = {
    label: "Home",
    recipientName: "ByteMe Customer",
    phone: "012345678",
    addressLine: "BKK1, Phnom Penh, Cambodia",
    latitude: 11.5564,
    longitude: 104.9282,
    isDefault: true,
  };

  const existingAddress = await prisma.address.findFirst({
    where: { userId: customer.id, label: addressData.label },
  });

  if (existingAddress) {
    await prisma.address.update({
      where: { id: existingAddress.id },
      data: addressData,
    });
  } else {
    await prisma.address.create({
      data: { userId: customer.id, ...addressData },
    });
  }

  console.log("ByteMe seed completed.");
  console.log("Customer: customer@byteme.test");
  console.log("Demo password: ByteMe123!");
  console.log("Created/updated 3 shops and 9 products.");
}

main()
  .catch((error) => {
    console.error("Seeding failed:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
