import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import authRoutes from "../src/modules/auth/auth.routes.js";
import shopRoutes from "./modules/shops/shop.routes.js";
import shopCategoryRoutes from "./modules/shops/shop-categories/shop-category.routes.js";

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.get("/api/health", (_req, res) => {
  res.status(200).json({
    success: true,
    message: "ByteFood API is running",
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/shops", shopRoutes);
app.use("/api/shop-categories", shopCategoryRoutes);
export default app;
