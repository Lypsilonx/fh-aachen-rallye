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
        Schema::create('challenge_states', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users', 'id')->onDelete('cascade');
            $table->string('challenge_id', 255)->constrained('challenges', 'challenge_id')->onDelete('cascade');
            $table->integer('step');
            $table->integer('shuffleSource')->nullable();
            $table->string('shuffleTargets')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('challenge_states');
    }
};
