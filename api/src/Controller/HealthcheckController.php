<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Component\Routing\Annotation\Route;

#[AsController]
#[Route(path: '/')]
#[Route(path: '/health')]
#[Route(path: '/status')]
final readonly class HealthcheckController
{
    public function __invoke(): JsonResponse
    {
        return new JsonResponse('ok');
    }
}
