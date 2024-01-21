<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Order;
use Symfony\Component\Uid\Uuid;

final class OrderRepository
{
    public function save(Order $order, bool $flush = false): void
    {
        if ($flush) {
            $order->setId(Uuid::v4()->toRfc4122());
        }

        // fake repository, just for demo
        usleep(10_000);
    }
}
