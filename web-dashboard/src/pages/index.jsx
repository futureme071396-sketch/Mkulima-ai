import { useEffect } from "react";
import { useRouter } from "next/router";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    router.push("/Dashboard"); // redirect to dashboard page
  }, []);

  return <div>Redirecting to Dashboard...</div>;
}