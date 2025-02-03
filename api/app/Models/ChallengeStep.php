<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class ChallengeStep extends Model
{
    /** @use HasFactory<\Database\Factories\ChallengeStepFactory> */
    use HasFactory, HasUuids;

    protected $fillable = [
        'challenge_id',
        'index',
        'type',
        'text',
        'next',
        'punishment',
        'alternatives',
        'isLast',
        'options',
        'correctAnswer',
        'indexOnIncorrect',
        'hintCost',
    ];

    public function challenge()
    {
        return $this->belongsTo(Challenge::class);
    }
}
