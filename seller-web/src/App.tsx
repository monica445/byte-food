import { Store } from "lucide-react";
import logo from "./assets/logo.png";

function App() {
  return (
    <main className="min-h-screen bg-background text-text-primary">
      <nav className="flex items-center justify-between border-b border-border bg-surface px-6 py-5 sm:px-12 lg:px-20">
        <a href="/" className="flex items-center gap-3">
          <img
            src={logo}
            alt="ByteMe logo"
            className="size-14 rounded-xl object-contain"
          />
        </a>

        <span className="text-sm text-text-secondary">Seller Dashboard</span>
      </nav>

      {/* Welcome Section */}
      <section className="flex min-h-[calc(100vh-81px)] flex-col items-center justify-center px-6 py-16 text-center">
        <div className="mb-7 grid size-24 place-items-center rounded-3xl bg-primary-light text-primary">
          <Store size={44} strokeWidth={1.8} />
        </div>

        <p className="mb-3 text-xs font-extrabold tracking-[0.3em] text-primary">
          BYTE FOOD DELIVERY
        </p>

        <h1 className="text-4xl font-extrabold tracking-tight sm:text-5xl lg:text-6xl">
          Welcome to <span className="text-primary">ByteMe</span>
        </h1>

        <p className="mt-5 max-w-md text-sm leading-7 text-text-secondary sm:text-base">
          Manage your shop, share your favorite food, and keep every order
          moving with ease.
        </p>

        <button
          type="button"
          onClick={() => alert("Welcome to ByteMe!")}
          className="mt-8 inline-flex items-center gap-3 rounded-xl bg-primary px-7 py-4 font-semibold text-primary-foreground transition hover:-translate-y-0.5 hover:bg-primary-hover focus:outline-none focus:ring-4 focus:ring-primary/20"
        >
          Get Started
          <span aria-hidden="true">→</span>
        </button>

        <p className="mt-12 text-sm text-text-muted">
          Delicious food. Simple ordering.
        </p>
      </section>
    </main>
  );
}

export default App;
