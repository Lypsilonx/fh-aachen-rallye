<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Translation extends Model
{
    /** @use HasFactory<\Database\Factories\TranslationFactory> */
    use HasFactory, HasUuids;

    protected $fillable = [
        'key',
        'language',
        'value',
    ];
}
