<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdateChallengeStepRequest extends FormRequest
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

        return $user->tokenCan('update:challengeSteps');
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
                'index' => ['required', 'integer'],
                'type' => ['required', 'string', 'max:255'],
                'text' => ['required', 'string'],
                'next' => ['required', 'integer'],
                'isLast' => ['required', 'boolean'],
                'options' => ['required', 'string'],
                'correctAnswer' => ['required', 'string'],
                'indexOnIncorrect' => ['required', 'integer'],
            ];
        } else {
            return [
                'challenge_id' => ['sometimes', 'required', 'uuid', 'exists:challenges,id'],
                'index' => ['sometimes', 'required', 'integer'],
                'type' => ['sometimes', 'required', 'string', 'max:255'],
                'text' => ['sometimes', 'required', 'string'],
                'next' => ['sometimes', 'required', 'integer'],
                'isLast' => ['sometimes', 'required', 'boolean'],
                'options' => ['sometimes', 'required', 'string'],
                'correctAnswer' => ['sometimes', 'required', 'string'],
                'indexOnIncorrect' => ['sometimes', 'required', 'integer'],
            ];
        }
    }
}
