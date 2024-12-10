<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTranslationRequest extends FormRequest
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

        return $user->tokenCan('update:translations');
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
                'key' => ['required', 'string', 'max:255'],
                'language' => ['required', 'string', 'max:255'],
                'value' => ['required', 'string'],
            ];
        } else {
            return [
                'key' => ['sometimes', 'required', 'string', 'max:255'],
                'language' => ['sometimes', 'required', 'string', 'max:255'],
                'value' => ['sometimes', 'required', 'string'],
            ];
        }
    }
}
