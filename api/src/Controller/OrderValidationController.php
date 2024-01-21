<?php

declare(strict_types=1);

namespace App\Controller;

use App\Entity\Order;
use Google\ApiCore\ApiException;
use Google\Cloud\Tasks\V2\CloudTasksClient;
use Google\Cloud\Tasks\V2\HttpMethod;
use Google\Cloud\Tasks\V2\HttpRequest;
use Google\Cloud\Tasks\V2\Task;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Routing\RouterInterface;
use Symfony\Component\Serializer\SerializerInterface;

#[AsController]
#[Route(
    path: '/order_validation',
    name: 'order_validation',
    methods: ['POST']
)]
final readonly class OrderValidationController
{
    public function __construct(
        private string $orderQueue,
        private string $internalHost,
        private SerializerInterface $serializer,
        private RouterInterface $router,
    ) {}

    public function __invoke(#[MapRequestPayload] Order $order): JsonResponse
    {
        /**
         * On valide que la commande est correct, on pourrait aussi valider que la commande n'est pas vide ou alors que
         * certaines données sont transmises de la bonne manière en utilisant le composant symfony/validator
         */
        if (empty($order->getConfirmationCode())) {
            return new JsonResponse(
                data: ['error' => 'order.confirmation_code.empty'],
                status: Response::HTTP_BAD_REQUEST,
            );
        }

        /**
         * On simule ici un appel au prestataire de paiement pour valider que la commande est bonne.
         * Dans le cas où le prestataire est trop lent à répondre, on peut aussi le faire de manière asynchrone.
         */
        usleep(50_000); // 50ms

        /**
         * On peut envoyer dans CloudTask le traitement asynchrone, ainsi, on réduit le délai de réponse de cette route
         */
        try {
            $this->sendOrderTransactionTask($order);
        } catch (ApiException) {
            return new JsonResponse(
                data: ['error' => 'order.system_unavailable'],
                status: Response::HTTP_SERVICE_UNAVAILABLE,
            );
        }

        return new JsonResponse(status: Response::HTTP_NO_CONTENT);
    }

    /**
     * @throws ApiException
     */
    private function sendOrderTransactionTask(Order $order): void
    {
        /**
         * On va créer une tache de type HttpRequest qui va correspondre à la requête à exécuter de manière asynchrone.
         */
        $taskRequest = new HttpRequest();
        $taskRequest->setHttpMethod(HttpMethod::POST);
        $taskRequest->setHeaders([
            'Content-Type' => 'application/json'
        ]);
        $taskRequest->setBody($this->serializer->serialize($order, 'json'));
        $taskRequest->setUrl(sprintf("%s%s", $this->internalHost, $this->router->generate('order_transaction')));

        $task = new Task();
        $task->setHttpRequest($taskRequest);

        $client = new CloudTasksClient();
        $client->createTask($this->orderQueue, $task);
    }
}
