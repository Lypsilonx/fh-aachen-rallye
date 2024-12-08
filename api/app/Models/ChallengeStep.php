<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChallengeStep extends Model
{
    /** @use HasFactory<\Database\Factories\ChallengeStepFactory> */
    use HasFactory;

    public function challenge()
    {
        return $this->belongsTo(Challenge::class);
    }
}
