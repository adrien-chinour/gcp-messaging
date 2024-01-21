<?php

declare(strict_types=1);

namespace App\Webhook;

use Google\Cloud\Core\Exception\GoogleException;
use Google\Cloud\PubSub\Message;

trait IncomingPubSubMessageTrait
{
    /**
     * @throws GoogleException
     */
    public function getMessage(array $message): Message
    {
        if (!isset($message['message'])) {
            throw new GoogleException('Invalid message data.');
        }

        if (isset($message['message']['data'])) {
            $message['message']['data'] = base64_decode($message['message']['data']);
        }

        return new Message($message['message'], [
            'ackId' => $message['ackId'] ?? null,
            'deliveryAttempt' => $message['deliveryAttempt'] ?? null,
        ]);
    }
}
