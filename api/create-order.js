const Razorpay = require('razorpay');
const crypto = require('crypto');

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method not allowed.' });
  }

  const keyId = process.env.RAZORPAY_KEY_ID;
  const keySecret = process.env.RAZORPAY_KEY_SECRET;

  if (!keyId || !keySecret) {
    return res.status(500).json({
      error: 'Missing Razorpay server credentials.',
    });
  }

  const body = parseBody(req.body);
  const amount = Number(body.amount);
  const currency = typeof body.currency === 'string' ? body.currency : 'INR';
  const receipt =
    typeof body.receipt === 'string' && body.receipt.trim().length > 0
      ? body.receipt.trim()
      : `jpumun_${crypto.randomUUID()}`;

  if (!Number.isFinite(amount) || amount < 100) {
    return res.status(400).json({
      error: 'Amount must be at least 100 paise.',
    });
  }

  try {
    const razorpay = new Razorpay({
      key_id: keyId,
      key_secret: keySecret,
    });

    const order = await razorpay.orders.create({
      amount: Math.round(amount),
      currency,
      receipt,
    });

    return res.status(200).json({
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      key_id: keyId,
    });
  } catch (error) {
    const statusCode =
      typeof error?.statusCode === 'number'
        ? error.statusCode
        : typeof error?.status === 'number'
        ? error.status
        : 500;

    if (statusCode === 401) {
      return res.status(401).json({
        error: 'Razorpay authentication failed.',
      });
    }

    return res.status(500).json({
      error: error?.error?.description || error?.message || 'Failed to create order.',
    });
  }
};

function parseBody(body) {
  if (!body) {
    return {};
  }

  if (typeof body === 'string') {
    try {
      return JSON.parse(body);
    } catch (_) {
      return {};
    }
  }

  return body;
}
