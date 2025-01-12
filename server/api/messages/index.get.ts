import { defineEventHandler } from 'h3';
import { pool } from '~/server/db';
import { Message } from '~/server/types';

// Handler to get all messages
export default defineEventHandler(async (event) => {
  const [rows] = await pool.query('SELECT * FROM messages');

  return rows as Message[];
});
