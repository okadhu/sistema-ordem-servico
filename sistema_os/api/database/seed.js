import fs from "fs";
import path from "path";
import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

async function seedDatabase() {
  try {
    console.log("🌱 Conectando ao MySQL...");

    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      port: process.env.DB_PORT || 3306,
      multipleStatements: true
    });

    const filePath = path.join(process.cwd(), "database", "seed.sql");
    const sql = fs.readFileSync(filePath, "utf8");

    console.log("🌾 Inserindo dados iniciais...");
    await connection.query(sql);

    console.log("✅ SEED executado com sucesso!");
    process.exit(0);
  } catch (err) {
    console.error("❌ Erro ao rodar seed:", err);
    process.exit(1);
  }
}

seedDatabase();
