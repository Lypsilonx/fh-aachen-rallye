<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('challenge_steps', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('challenge_id')->constrained('challenges', 'id')->onDelete('cascade');
            $table->string('type');
            $table->string('text');
            $table->integer('next')->nullable();
            $table->boolean('isLast');

            // ChallengeStepOptions
            $table->string('options')->nullable();

            // ChallengeStepStringInput
            $table->string('correctAnswer')->nullable();
            $table->integer('indexOnIncorrect')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('challenge_steps');
    }
};
