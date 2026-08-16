import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = __ENV.BASE_URL;

if (!BASE_URL) {
  throw new Error(
    "BASE_URL is required. Example: k6 run -e BASE_URL=http://example.com load-test/k6.js"
  );
}

export const options = {
  stages: [
    { duration: "30s", target: 10 },
    { duration: "1m", target: 25 },
    { duration: "1m", target: 50 },
    { duration: "1m", target: 100 },
    { duration: "1m", target: 200 },
    { duration: "30s", target: 0 },
  ],

  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<500"],
    checks: ["rate>0.99"],
  },
};

export default function () {
  const response = http.get(`${BASE_URL}/`, {
    tags: {
      endpoint: "home",
    },
  });

  check(response, {
    "status is 200": (r) => r.status === 200,
    "nginx page returned": (r) =>
      r.body && r.body.includes("Welcome to nginx"),
  });

  sleep(0.2);
}
