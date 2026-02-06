import fs from "fs";
import path from "path";
import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

async function initDatabase() {
  try {
    console.log("🔄 Conectando ao MySQL...");

    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      port: process.env.DB_PORT || 3306,
      multipleStatements: true,
    });

    const sqlFile = path.join(process.cwd(), "database", "create_tables.sql");
    const sql = fs.readFileSync(sqlFile, "utf8");

    console.log("📦 Executando script SQL...");
    await connection.query(sql);

    console.log("✅ Banco de dados criado/configurado com sucesso!");
    process.exit(0);
  } catch (err) {
    console.error("❌ Erro ao criar banco:", err);
    process.exit(1);
  }
}

initDatabase();
