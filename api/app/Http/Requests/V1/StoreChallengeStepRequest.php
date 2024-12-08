<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreChallengeStepRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'challenge_id' => ['required', 'integer', 'exists:challenges,id'],
            'type' => ['required', 'string', 'max:255'],
            'text' => ['required', 'string'],
            'next' => ['required', 'integer'],
            'isLast' => ['required', 'boolean'],
            'options' => ['required', 'string'],
            'correctAnswer' => ['required', 'string'],
            'indexOnIncorrect' => ['required', 'integer'],
        ];
    }
}
