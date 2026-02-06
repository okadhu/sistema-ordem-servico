import express from "express";
import {
  createOrder,
  listOrders,
  getOrder,
  updateOrder
} from "../controllers/ordersController.js";

import { authMiddleware } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/create", authMiddleware, createOrder);
router.get("/", authMiddleware, listOrders);
router.get("/:id", authMiddleware, getOrder);
router.put("/:id", authMiddleware, updateOrder);

export default router;
