import { createClient } from "@supabase/supabase-js";

export const dynamic = "force-dynamic";

// Reads the todos table from the VM's local Supabase (see .homemade/config.json).
export default async function Home() {
  const supabase = createClient(process.env.SUPABASE_URL ?? "", process.env.SUPABASE_ANON_KEY ?? "");
  const { data, error } = await supabase.from("todos").select("id, title, done").order("id");
  return (
    <main className="mx-auto max-w-xl p-10 font-sans">
      <h1 className="text-2xl font-semibold">Next.js + Supabase</h1>
      <p className="mt-2 text-zinc-500">These rows come from the local Supabase in this VM.</p>
      {error ? <p className="mt-6 text-red-600">{error.message}</p> : null}
      <ul className="mt-6 space-y-2">
        {(data ?? []).map((todo) => (
          <li key={todo.id}>
            {todo.done ? "Done: " : ""}
            {todo.title}
          </li>
        ))}
      </ul>
    </main>
  );
}
