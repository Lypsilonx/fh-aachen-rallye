<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
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
            'username' => $this->username,
            'points' => $this->points,
            'displayName' => $this->displayName,
            'challengeStates' => ChallengeStateResource::collection($this->whenLoaded('challengeStates')),
        ];
    }
}