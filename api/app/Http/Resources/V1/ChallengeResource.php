<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChallengeResource extends JsonResource
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
            'challenge_id' => $this->challenge_id,
            'title' => $this->title,
            'language' => $this->language,
            'difficulty' => $this->difficulty,
            'points' => $this->points,
            'category' => $this->category,
            'descriptionStart' => $this->descriptionStart,
            'descriptionEnd' => $this->descriptionEnd,
            'image' => $this->image,
            'steps' => ChallengeStepResource::collection($this->whenLoaded('steps')),
        ];
    }
}
