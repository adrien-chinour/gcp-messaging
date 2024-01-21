<?php

declare(strict_types=1);

namespace App\Entity;

class Order
{
    private ?string $id = null;

    private ?string $confirmationCode = null;

    public function getId(): ?string
    {
        return $this->id;
    }

    public function setId(?string $id): static
    {
        $this->id = $id;

        return $this;
    }

    public function getConfirmationCode(): ?string
    {
        return $this->confirmationCode;
    }

    public function setConfirmationCode(string $confirmationCode): static
    {
        $this->confirmationCode = $confirmationCode;

        return $this;
    }
}
