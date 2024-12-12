<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\ResourceCollection;
use App\Models\ChallengeState;

class ChallengeCollection extends ResourceCollection
{
    /**
     * Transform the resource collection into an array.
     *
     * @return array<int|string, mixed>
     */
    public function toArray(Request $request): array
    {
        return $this->collection->filter(function ($challenge) {
            if (!auth()->user()->tokenCan('read:challenges:locked')) {
                if ($challenge->lock_id && ChallengeState::where('user_id', auth()->id())->where('challenge_id', $challenge->challenge_id)->doesntExist()) {
                    return false;
                }
            }
            return true;
        })->toArray();
    }
}
