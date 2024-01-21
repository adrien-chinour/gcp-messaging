<?php

declare(strict_types=1);

namespace App\Controller;

use App\Entity\Order;
use App\Repository\OrderRepository;
use Google\Cloud\PubSub\PubSubClient;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Serializer\SerializerInterface;

#[AsController]
#[Route(
    path: '/order_transaction',
    name: 'order_transaction',
    methods: ['POST'],
    condition: 'env("ALLOW_INTERNAL") == 1')
]
final readonly class OrderTransactionController
{
    public function __construct(
        private OrderRepository $orderRepository,
        private SerializerInterface $serializer,
    ) {}

    public function __invoke(#[MapRequestPayload] Order $order): JsonResponse
    {
        /**
         * On commence par sauvegarder notre commande en base de données
         */
        $this->orderRepository->save($order, true);

        /**
         * On vient ensuite pousser un message pour indiquer qu'une nouvelle commande a été traité
         * Cela va nous permettre de traiter l'envoi de mail ect
         */
        $this->sendOrderTransactionMessage($order);

        return new JsonResponse(Response::HTTP_CREATED);
    }

    public function sendOrderTransactionMessage(Order $order): void
    {
        $pubSub = new PubSubClient();

        // On pousse sur le topic "order-events" notre message
        $topic = $pubSub->topic('order-events');
        $topic->publish([
            'data' => $this->serializer->serialize($order, 'json'),
            'attributes' => [
                'message' => 'order_transaction:succeed'
            ],
        ]);
    }
}
