<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class ChallengeState extends Model
{
    /** @use HasFactory<\Database\Factories\ChallengeStateFactory> */
    use HasFactory, HasUuids;

    protected $fillable = [
        'challenge_id',
        'user_id',
        'step',
        'shuffleSource',
        'shuffleTargets',
        'otherShuffleTargets',
        'stringInputHint',
        'userStatus',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
