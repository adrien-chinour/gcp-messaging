<?php

declare(strict_types=1);

namespace App\Webhook;

use App\Entity\Order;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Serializer\SerializerInterface;

#[AsController]
#[Route(
    path: '/order_validated_email',
    name: 'order_validated_email',
    methods: ['POST'],
    condition: 'env("ALLOW_INTERNAL") == 1',
)]
final readonly class OrderValidatedEmailWebhook
{
    use IncomingPubSubMessageTrait;

    public function __construct(private SerializerInterface $serializer) {}

    public function __invoke(Request $request): JsonResponse
    {
        $message = $this->getMessage($request->toArray());
        if ('order_transaction:succeed' !== $message->attribute('message')) {
            return new JsonResponse(status: Response::HTTP_BAD_REQUEST);
        }

        try {
            $order = $this->serializer->deserialize($message->data(), Order::class, 'json');
        } catch (\Throwable) {
            return new JsonResponse(status: Response::HTTP_NOT_ACCEPTABLE);
        }

        // use mailer to send email with order details
        usleep(20_000);

        return new JsonResponse(['order' => $order->getId()]);
    }
}
