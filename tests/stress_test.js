import { check } from 'k6';
import http from 'k6/http';

import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

export const options = {
    scenarios: {
        stress: {
            executor: 'ramping-vus',
            startVUs: 10,
            stages: [
                { duration: '10s', target: 100 },
                { duration: '20s', target: 200 },
                { duration: '30s', target: 400 },
                { duration: '30s', target: 400 },
                { duration: '30s', target: 0 },
            ],
            gracefulRampDown: '10s',
        },
    }
}

export default function () {
    const body = {
        confirmation_code: randomString(10),
    };

    const res = http.post(
        `https://${__ENV.HOSTNAME}/order_validation`,
        JSON.stringify(body),
        {
            headers: {
                'Content-Type': 'application/json',
            },
        }
    );

    check(res, {
        'is status 204': (r) => r.status === 204,
    });
}
