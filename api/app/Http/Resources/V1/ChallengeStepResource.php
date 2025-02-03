<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChallengeStepResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'index' => $this->index,
            'challenge_id' => $this->challenge_id,
            'type' => $this->type,
            'text' => $this->text,
            'next' => $this->next,
            'punishment' => $this->punishment,
            'alternatives' => $this->alternatives,
            'isLast' => $this->isLast,
            'options' => $this->options,
            'correctAnswer' => $this->correctAnswer,
            'indexOnIncorrect' => $this->indexOnIncorrect,
            'hintCost' => $this->hintCost,
        ];
    }
}
