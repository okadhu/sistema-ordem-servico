import { db } from "../config/db.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

export async function login(req, res) {
  console.log("🔥 BODY RECEBIDO:", req.body);

  const { email, password } = req.body;

  const [rows] = await db.query("SELECT * FROM users WHERE email = ?", [email]);

  if (rows.length === 0) {
    return res.status(400).json({ error: "Usuário não encontrado" });
  }

  const user = rows[0];

  console.log("🔥 SENHA DIGITADA:", password);
  console.log("🔥 SENHA NO BANCO:", user.password);  // <-- CORRIGIDO

  const validPass = await bcrypt.compare(password, user.password); // <-- CORRIGIDO
  console.log("🔥 RESULTADO bcrypt.compare:", validPass);

  if (!validPass) {
    return res.status(401).json({ error: "Senha incorreta" });
  }

  const token = jwt.sign(
    { id: user.id, cargo: user.cargo }, // <-- role/cargo
    process.env.JWT_SECRET,
    { expiresIn: "8h" }
  );

  return res.json({ token, user });
}
