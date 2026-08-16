import http from "k6/http";
import { check } from "k6";

const BASE_URL = __ENV.BASE_URL;

if (!BASE_URL) {
  throw new Error("BASE_URL is required");
}

export const options = {
  discardResponseBodies: true,

  scenarios: {
    load_200: {
      executor: "constant-vus",
      vus: 200,
      duration: "45s",
      startTime: "0s",
      gracefulStop: "5s",
    },

    load_400: {
      executor: "constant-vus",
      vus: 400,
      duration: "45s",
      startTime: "55s",
      gracefulStop: "5s",
    },

    load_600: {
      executor: "constant-vus",
      vus: 600,
      duration: "45s",
      startTime: "1m50s",
      gracefulStop: "5s",
    },

    load_800: {
      executor: "constant-vus",
      vus: 800,
      duration: "45s",
      startTime: "2m45s",
      gracefulStop: "5s",
    },

    load_1000: {
      executor: "constant-vus",
      vus: 1000,
      duration: "45s",
      startTime: "3m40s",
      gracefulStop: "5s",
    },
  },

  thresholds: {
    "http_req_failed{scenario:load_200}": ["rate<0.01"],
    "http_req_duration{scenario:load_200}": ["p(95)<500"],

    "http_req_failed{scenario:load_400}": ["rate<0.01"],
    "http_req_duration{scenario:load_400}": ["p(95)<500"],

    "http_req_failed{scenario:load_600}": ["rate<0.01"],
    "http_req_duration{scenario:load_600}": ["p(95)<500"],

    "http_req_failed{scenario:load_800}": ["rate<0.01"],
    "http_req_duration{scenario:load_800}": ["p(95)<500"],

    "http_req_failed{scenario:load_1000}": ["rate<0.01"],
    "http_req_duration{scenario:load_1000}": ["p(95)<500"],
  },
};

export default function () {
  const response = http.get(`${BASE_URL}/`);

  check(response, {
    "status is 200": (r) => r.status === 200,
  });
}
