import { db } from "../config/db.js";
export async function createOrder(req, res) {
  try {
    console.log("BODY RECEBIDO:", req.body);
    console.log("USER LOGADO:", req.user);

    const operador_id = req.user.id; // ← PEGANDO DO TOKEN

    const { sector_id, machine_id, priority, description } = req.body;

const [result] = await db.query(
  `INSERT INTO orders
   (code, setor, maquina, prioridade, descricao, operador_id)
   VALUES (?, ?, ?, ?, ?, ?)`,
  [
    `OS-${Date.now()}`,
    sector_id,
    machine_id,
    priority,
    description,
    operador_id
  ]
);


    return res.json({ message: "OS criada!", id: result.insertId });

  } catch (e) {
    console.error("ERRO AO CRIAR OS:", e);
    return res.status(500).json({ error: "Erro interno ao criar OS" });
  }
}
export async function listOrders(req, res) {
  try {
    const [rows] = await db.query(`
      SELECT 
        o.*, 
        u.nome AS operador_nome,
        m.id AS machine_id,
        m.nome AS machine_nome
      FROM orders o
      LEFT JOIN users u ON u.id = o.operador_id
      LEFT JOIN machines m ON m.id = o.maquina
      ORDER BY o.data_abertura DESC
    `);

    return res.json(rows);

  } catch (e) {
    console.error("ERRO AO LISTAR OS:", e);
    return res.status(500).json({ error: "Erro ao listar ordens" });
  }
}

export async function getOrder(req, res) {
  try {
    const { id } = req.params;

    const [rows] = await db.execute(`
      SELECT 
        o.*,
        u.nome AS operador_nome,
        m.nome AS maquina_nome,
        s.nome AS setor_nome
      FROM orders o
      LEFT JOIN users u ON u.id = o.operador_id
      LEFT JOIN machines m ON m.id = o.maquina
      LEFT JOIN sectors s ON s.id = o.setor
      WHERE o.id = ?
    `, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: "OS não encontrada" });
    }

    return res.json(rows[0]);

  } catch (e) {
    console.error("ERRO AO BUSCAR OS:", e);
    return res.status(500).json({ error: "Erro ao buscar ordem" });
  }
}


export async function updateOrder(req, res) {
  try {
    const { id } = req.params;
    const data = req.body;

    await db.query("UPDATE orders SET ? WHERE id = ?", [data, id]);

    return res.json({ message: "OS atualizada!" });

  } catch (e) {
    console.error("ERRO AO ATUALIZAR OS:", e);
    return res.status(500).json({ error: "Erro ao atualizar ordem" });
  }
}
  const getAllOrders = async (req, res) => {
  try {
   const [rows] = await db.query(`
  SELECT 
      o.*, 
      u.nome AS operador_nome,
      m.id AS machine_id,
      m.nome AS machine_nome
  FROM orders o
  LEFT JOIN users u ON u.id = o.operador_id
  LEFT JOIN machines m ON m.id = o.maquina
  ORDER BY o.id DESC
`);


    return res.json(rows);
  } catch (err) {
    console.log("ERRO AO BUSCAR OS:", err);
    return res.status(500).json({ error: "Erro ao listar OS" });
  }
};
