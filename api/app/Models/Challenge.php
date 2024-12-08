<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Challenge extends Model
{
    /** @use HasFactory<\Database\Factories\ChallengeFactory> */
    use HasFactory;

    protected $fillable = [
        'title',
        'difficulty',
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
