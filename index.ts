import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { Request, Response } from 'express';
import { Pool } from 'pg';

// PostgreSQL setup
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'AngelOne',
  password: 'Anchit19%',
  port: 5432,
});

// Route handlers
export const getStocks = async (req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT * FROM watchlist ORDER BY id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
};

export const addStock = async (req: Request, res: Response) => {
  const { stock_name, symbol } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO watchlist (stock_name, symbol) VALUES ($1, $2) RETURNING *',
      [stock_name, symbol]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
};

export const deleteStock = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM watchlist WHERE id = $1', [id]);
    res.send('Stock deleted');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
};

// Router setup
const router = express.Router();

router.get('/watchlist', getStocks);
router.post('/addStock', addStock);
router.delete('/deleteStock/:id', deleteStock);

// Express app setup
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Routes
app.use('/api', router);

// Root route
app.get('/', (req: Request, res: Response) => {
  res.send('Welcome to the Watchlist API! Use /api for the actual API routes.');
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
