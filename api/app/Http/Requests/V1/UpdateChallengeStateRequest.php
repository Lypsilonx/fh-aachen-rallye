<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdateChallengeStateRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = $this->user();

        if ($user === null) {
            return false;
        }

        return $user->tokenCan('update:challengeStates');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $method = $this->method();

        if ($method === 'PUT') {
            return [
                'challenge_id' => ['required', 'uuid', 'exists:challenges,id'],
                'user_id' => ['required', 'uuid', 'exists:users,id'],
                'step' => ['required', 'integer'],
            ];
        } else {
            return [
                'challenge_id' => ['sometimes', 'required', 'uuid', 'exists:challenges,id'],
                'user_id' => ['sometimes', 'required', 'uuid', 'exists:users,id'],
                'step' => ['sometimes', 'required', 'integer'],
            ];
        }
    }
}