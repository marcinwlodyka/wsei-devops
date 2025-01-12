import { defineEventHandler, readBody } from 'h3';
import { pool } from '~/server/db';

// Handler to add a new message
export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { message } = body;

  await pool.query('INSERT INTO messages (message) VALUES (?)', [message]);

  return { message: 'Message added successfully' };
});
