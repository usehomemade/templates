import { createClient } from "redis";

// Counts visits in the VM's Redis: GET /api/visits.
const redis = createClient({ url: process.env.REDIS_URL });
const connecting = redis.connect();

export async function GET() {
  await connecting;
  const visits = await redis.incr("visits");
  return Response.json({ visits });
}
