<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChallengeStateResource extends JsonResource
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
            'user_id' => $this->user_id,
            'step' => $this->step,
            'shuffleSource' => $this->shuffleSource,
            'shuffleTargets' => $this->shuffleTargets,
            'userStatus' => $this->userStatus,
        ];
    }
}
