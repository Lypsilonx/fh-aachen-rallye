<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Challenge extends Model
{
    /** @use HasFactory<\Database\Factories\ChallengeFactory> */
    use HasFactory, HasUuids;

    protected $fillable = [
        'challenge_id',
        'title',
        'difficulty',
        'tags',
        'duration',
        'points',
        'category',
        'descriptionStart',
        'descriptionEnd',
        'image',
    ];

    public function steps()
    {
        return $this->hasMany(ChallengeStep::class);
    }
}
